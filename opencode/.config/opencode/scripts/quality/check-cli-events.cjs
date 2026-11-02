const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');
const ts = require('typescript');
// Node's default Solid export disables effects; use its public browser CJS export.
const solid = require('solid-js/dist/solid.cjs');

const root = path.resolve(__dirname, '../..');

async function fixture(name, initialStatuses = {}) {
  const commands = [];
  const errors = [];
  const fetched = [];
  const [tabs, setTabs] = solid.createSignal([]);
  const [route, setRoute] = solid.createSignal({ type: 'session', sessionID: 'main' });
  const [statuses, setStatuses] = solid.createSignal(initialStatuses);
  const [permissions, setPermissions] = solid.createSignal({});
  const [forms, setForms] = solid.createSignal({});
  let listener;
  let unsubscribed = false;
  const { Plugin: { define } } = await import('@opencode/plugin/tui');
  const exports = {};
  const code = ts.transpileModule(fs.readFileSync(path.join(root, `plugins/${name}/tui.ts`), 'utf8'), {
    compilerOptions: { target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.CommonJS },
  }).outputText;
  vm.runInNewContext(code, {
    exports, AbortController, console: { error: (...args) => errors.push(args) },
    process: { platform: 'darwin', env: {} },
    require(name) {
      if (name === '@opencode/plugin/tui') return { Plugin: { define } };
      if (name === 'solid-js') return solid;
      if (name === 'node:child_process') return {
        execFile(command, args, options, callback) {
          commands.push([command, ...args]);
          callback(null, '', '');
        },
      };
      return require(name);
    },
  });
  const sessions = {
    main: { id: 'main', location: { directory: '/project' } },
    child: { id: 'child', parentID: 'main', location: { directory: '/project' } },
    other: { id: 'other', location: { directory: '/project' } },
  };
  const cached = { ...sessions };
  const cleanup = await exports.default.setup({
    location: { directory: '/project' },
    client: { session: { get: async ({ sessionID }) => { fetched.push(sessionID); return sessions[sessionID]; } } },
    data: {
      listen(callback) { listener = callback; return () => { unsubscribed = true; listener = undefined; }; },
      location: { default: () => ({ directory: '/project' }) },
      session: {
        get: id => cached[id], root: id => cached[id]?.parentID ?? id,
        family: id => Object.values(cached).filter(session => session.id === id || session.parentID === id).map(session => session.id),
        status: id => statuses()[id] ?? 'idle',
        permission: { list: id => permissions()[id] ?? [] },
        form: { list: id => forms()[id] ?? [] },
      },
    },
    ui: { router: { current: route }, tabs: { list: tabs } },
  });
  if (name === 'notification') assert.equal(typeof listener, 'function', 'must subscribe through CLI data.listen');
  async function settle() {
    await new Promise(resolve => setImmediate(resolve));
    assert.deepEqual(errors, [], 'handlers must not fail silently');
  }
  await settle();
  return {
    commands, sessions, cached, fetched,
    settle, setRoute, setTabs,
    openTab(sessionID) { setTabs(previous => [...previous, { sessionID }]); },
    setStatus(id, status) { setStatuses(previous => ({ ...previous, [id]: status })); },
    setPermissions(id, values) { setPermissions(previous => ({ ...previous, [id]: values })); },
    setForms(id, values) { setForms(previous => ({ ...previous, [id]: values })); },
    emitNow(type, data) { listener?.({ details: { type, data, location: { directory: '/project' } } }); },
    async emit(type, data, location = { directory: '/project' }) {
      listener?.({ details: { type, data, location } });
      await new Promise(resolve => setImmediate(resolve));
      assert.deepEqual(errors, [], 'event handlers must not fail silently');
    },
    async close() { await cleanup(); if (name === 'notification') assert.equal(unsubscribed, true); assert.deepEqual(errors, []); },
  };
}

  test('notification uses owned session location, including moved and uncached tabs', async (t) => {
    const f = await fixture('notification');
    t.after(() => f.close());
    await f.emit('permission.asked', { sessionID: 'other' }, { directory: '/elsewhere' });
    assert.equal(f.fetched.length, 0, 'do not fetch unrelated sessions');
    assert.equal(f.commands.length, 0);
    f.openTab('other');
    f.sessions.other = { id: 'other', location: { directory: '/elsewhere' } };
    delete f.cached.other;
    await f.emit('permission.asked', { sessionID: 'other' }, { directory: '/elsewhere' });
    assert.equal(f.commands.length, 1, 'owned tab in another directory must be handled');
    assert.deepEqual(f.fetched, ['other']);
    // The server moved main while the client cache still contains its old directory.
    f.sessions.main = { id: 'main', location: { directory: '/worktree' } };
    await f.emit('permission.asked', { sessionID: 'main' }, { directory: '/worktree' });
    assert.equal(f.commands.length, 2, 'moved session must notify');
    const before = f.commands.length;
    await f.emit('permission.asked', { sessionID: 'main' }, { directory: '/wrong' });
    assert.equal(f.commands.length, before, 'reject a location not belonging to the session');
  });

test('notifications preserve summaries, titles and child permission/question behavior', async (t) => {
  const f = await fixture('notification');
  t.after(() => f.close());
  await f.emit('session.execution.succeeded', { sessionID: 'other' });
  await f.emit('session.execution.succeeded', { sessionID: 'child' });
  await f.emit('permission.asked', { sessionID: 'main' }, { directory: '/elsewhere' });
  assert.equal(f.commands.length, 0);
  await f.emit('session.text.ended', { sessionID: 'main', text: 'Completed the change' });
  await f.emit('session.execution.succeeded', { sessionID: 'main' });
  await f.emit('form.created', { form: { sessionID: 'child', title: 'Question', fields: [{ title: 'Deploy', description: 'Deploy now?' }] } });
  await f.emit('permission.asked', { sessionID: 'child' });
  assert.deepEqual(f.commands, [
    ['osascript', '-e', 'display notification "Completed the change" with title "opencode"'],
    ['osascript', '-e', 'display notification "Deploy now?" with title "Question: Deploy"'],
    ['osascript', '-e', 'display notification "Permission required" with title "opencode"'],
  ]);
});

test('notification cleanup unsubscribes and discards queued commands', async () => {
    const f = await fixture('notification');
    f.emitNow('permission.asked', { sessionID: 'main' });
    await f.close();
    await f.emit('permission.asked', { sessionID: 'main' });
    assert.equal(f.commands.length, 0);
});
