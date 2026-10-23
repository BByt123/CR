// Each button owns one pointer so a second finger cannot release a held control.
export function bindTouchControls(root, onKey) {
  const releases = [];
  for (const button of root.querySelectorAll('[data-key]')) {
    let pointer = null;
    const code = button.dataset.key;
    const release = (event) => {
      if (pointer === null || (event && event.pointerId !== pointer)) return;
      const previous = pointer;
      pointer = null;
      button.classList.remove('held');
      if (button.hasPointerCapture(previous)) button.releasePointerCapture(previous);
      onKey('keyup', code);
    };
    button.addEventListener('pointerdown', (event) => {
      event.preventDefault();
      if (pointer !== null) return;
      pointer = event.pointerId;
      button.setPointerCapture(pointer);
      button.classList.add('held');
      onKey('keydown', code);
    });
    for (const type of ['pointerup', 'pointercancel', 'lostpointercapture']) {
      button.addEventListener(type, release);
    }
    button.addEventListener('contextmenu', (event) => event.preventDefault());
    releases.push(() => release());
  }
  return () => releases.forEach((release) => release());
}
