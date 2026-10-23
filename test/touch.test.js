import test from 'node:test';
import assert from 'node:assert/strict';
import { bindTouchControls } from '../src/touch.js';

function control(code) {
  const handlers = new Map();
  const classes = new Set();
  const captured = new Set();
  return {
    dataset: { key: code },
    classList: {
      add: (name) => classes.add(name),
      remove: (name) => classes.delete(name),
    },
    hasPointerCapture: (id) => captured.has(id),
    setPointerCapture: (id) => captured.add(id),
    releasePointerCapture: (id) => captured.delete(id),
    addEventListener(type, handler) { handlers.set(type, handler); },
    emit(type, pointerId) { handlers.get(type)({ pointerId, preventDefault() {} }); },
    held: () => classes.has('held'),
  };
}

test('touch controls allow simultaneous pointers and release only their own pointer', () => {
  const left = control('ArrowLeft');
  const go = control('ArrowUp');
  const events = [];
  const unbind = bindTouchControls({ querySelectorAll: () => [left, go] }, (type, code) => events.push(`${type}:${code}`));

  left.emit('pointerdown', 1);
  go.emit('pointerdown', 2);
  left.emit('pointerup', 3);
  assert.equal(left.held(), true);
  assert.equal(go.held(), true);
  assert.deepEqual(events, ['keydown:ArrowLeft', 'keydown:ArrowUp']);

  left.emit('pointercancel', 1);
  go.emit('pointerup', 2);
  assert.equal(left.held(), false);
  assert.equal(go.held(), false);
  assert.deepEqual(events, ['keydown:ArrowLeft', 'keydown:ArrowUp', 'keyup:ArrowLeft', 'keyup:ArrowUp']);
  unbind();
});

test('touch cleanup releases every held control once', () => {
  const left = control('ArrowLeft');
  const events = [];
  const unbind = bindTouchControls({ querySelectorAll: () => [left] }, (type, code) => events.push(`${type}:${code}`));
  left.emit('pointerdown', 1);
  unbind();
  unbind();
  left.emit('pointerup', 1);
  assert.deepEqual(events, ['keydown:ArrowLeft', 'keyup:ArrowLeft']);
  assert.equal(left.held(), false);
});
