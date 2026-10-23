import test from 'node:test';
import assert from 'node:assert/strict';
import { InputController } from '../src/input.js';

function key(target, type, code) {
  const event = new Event(type, { cancelable: true });
  Object.defineProperty(event, 'code', { value: code });
  target.dispatchEvent(event);
}

test('accelerating, steering, and drifting can be held together', () => {
  const target = new EventTarget();
  const input = new InputController({ target });
  try {
    for (const code of ['ArrowUp', 'ArrowLeft', 'Space']) key(target, 'keydown', code);
    input._lastTime -= 100;
    const state = input.getInput();
    assert.equal(state.throttle, 1);
    assert.ok(state.steer < 0);
    assert.equal(state.drift, true);
    key(target, 'keyup', 'ArrowLeft');
    assert.equal(input.getInput().throttle, 1);
    assert.equal(input.getInput().drift, true);
  } finally {
    input.dispose();
  }
});

test('backgrounding clears held controls and queued item presses', () => {
  const target = new EventTarget();
  const input = new InputController({ target });
  try {
    for (const code of ['ArrowUp', 'Space', 'KeyE']) key(target, 'keydown', code);
    target.dispatchEvent(new Event('blur'));
    const state = input.getInput();
    assert.equal(state.throttle, 0);
    assert.equal(state.drift, false);
    assert.equal(state.item, false);
    assert.equal(input.consumePressed('item'), false);
  } finally {
    input.dispose();
  }
});
