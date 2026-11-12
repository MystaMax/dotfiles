import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { closeOverlay, focused, hc, nextCommand, notify, openOverlay, panes, props, run, theme } from "herdr";

const bindings = {
  "shift-n": ["mod.open", { name: "named-space" }],
  "?": ["prefix.help"],
  "shift-/": ["prefix.help"],
  a: ["prefix.literal"],
  "ctrl-a": ["prefix.literal"],
  o: ["prefix.next-pane"],
  tab: ["prefix.next-pane"],
  c: ["tab.new"],
  n: ["tab.next"],
  p: ["tab.prev"],
  x: ["pane.close"],
  z: ["pane.zoom"],
  s: ["mod.open", { name: "picker" }],
  g: ["mod.open", { name: "picker" }],
  "shift-s": ["app.settings"],
  d: ["window.close"],
  "$": ["space.rename"],
  "shift-4": ["space.rename"],
  "shift-w": ["space.rename"],
  ",": ["tab.rename"],
  "shift-t": ["tab.rename"],
  "&": ["tab.close"],
  "shift-7": ["tab.close"],
  "shift-x": ["tab.close"],
  v: ["pane.split", { direction: "right" }],
  "|": ["pane.split", { direction: "right" }],
  "shift-\\": ["pane.split", { direction: "right" }],
  "\\": ["pane.split", { direction: "right" }],
  "%": ["pane.split", { direction: "right" }],
  "shift-5": ["pane.split", { direction: "right" }],
  "-": ["pane.split", { direction: "down" }],
  "\"": ["pane.split", { direction: "down" }],
  "shift-'": ["pane.split", { direction: "down" }],
  h: ["pane.go", { direction: "left" }],
  left: ["pane.go", { direction: "left" }],
  j: ["pane.go", { direction: "down" }],
  down: ["pane.go", { direction: "down" }],
  k: ["pane.go", { direction: "up" }],
  up: ["pane.go", { direction: "up" }],
  l: ["pane.go", { direction: "right" }],
  right: ["pane.go", { direction: "right" }]
};

const commandLabels = {
  "tab.new": "Create tab",
  "tab.next": "Next tab",
  "tab.prev": "Previous tab",
  "tab.rename": "Rename tab",
  "tab.close": "Close tab",
  "space.rename": "Rename space",
  "pane.close": "Close pane (no confirmation)",
  "pane.zoom": "Toggle pane zoom",
  "app.settings": "Open settings",
  "window.close": "Close window, keep terminals",
  "prefix.help": "Show prefix shortcuts",
  "prefix.literal": "Send literal Ctrl+A",
  "prefix.next-pane": "Next pane in this tab"
};

function shortcutRows() {
  const aliases = {
    "shift-/": "?", "shift-4": "$", "shift-7": "&", "shift-5": "%",
    "shift-\\": "|", "shift-'": "\"", "ctrl-a": "Ctrl+A", tab: "Tab",
    left: "Left", right: "Right", up: "Up", down: "Down"
  };
  const groups = new Map();
  for (const [key, action] of Object.entries(bindings)) {
    const id = JSON.stringify(action);
    if (!groups.has(id)) {
      const [command, args] = action;
      let label = commandLabels[command];
      if (command === "pane.go") label = `Focus pane ${args.direction}`;
      if (command === "pane.split") label = `Split ${args.direction}`;
      if (command === "mod.open") label = args.name === "named-space" ? "Create a named space" : "Open space/tab picker";
      groups.set(id, { keys: new Set(), label });
    }
    const label = aliases[key] ?? key.replace(/^shift-([a-z])$/, (_, letter) => `Shift+${letter.toUpperCase()}`);
    groups.get(id).keys.add(label);
  }
  return [...groups.values()].map(({ keys, label }) => ({ keys: [...keys].join(" / "), label }));
}

export default class LegacyPrefix extends View {
  init(_props, cx) {
    this.showHelp = props()?.mode === "help";
    this.handle = cx.focus_handle();
    this.handle.focus();
    const origin = focused();
    this.terminal = origin?.shown ?? origin?.terminal;
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command === "literal") await this.literal();
        if (command === "help") this.help();
      }
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  help() {
    this.close();
    openOverlay({ mod: "legacy-prefix", props: { mode: "help" }, kind: "dialog", width: 620, height: 740 });
  }

  async literal() {
    this.close();
    try {
      if (!this.terminal) throw new Error("No focused terminal to receive Ctrl+A.");
      const result = await hc(["keys", this.terminal, "ctrl+a"]);
      if (result.code !== 0) throw new Error(result.stderr || result.stdout || `hc exited ${result.code}`);
    } catch (error) {
      notify({ title: "Could not send Ctrl+A", body: String(error), level: "error" });
    }
  }

  nextPane() {
    const current = focused();
    const siblings = panes().filter((pane) => pane.tab === current?.tab);
    const index = siblings.findIndex((pane) => pane.pane === current?.pane);
    this.close();
    if (index < 0) {
      notify({ title: "Cannot select next pane", body: "No focused tab pane.", level: "warning" });
      return;
    }
    if (siblings.length === 1) return;
    if (siblings[index].zoomed) run("pane.zoom", { pane: current.pane });
    run("pane.focus", { pane: siblings[(index + 1) % siblings.length].pane });
  }

  key(event, cx) {
    cx.stop_propagation();
    if (event.key === "escape") return this.close();
    if (this.showHelp) return;
    const modified = event.modifiers.control || event.modifiers.alt || event.modifiers.platform;
    const action = bindings[event.keystroke] ?? (!modified && event.key_char ? bindings[event.key_char] : undefined);
    if (!action) {
      this.close();
      notify({
        title: "Unmapped prefix shortcut",
        body: `Ctrl+A, ${event.keystroke} is not mapped. Prefix cancelled.`,
        level: "warning"
      });
      return;
    }
    if (action[0] === "prefix.literal") return this.literal();
    if (action[0] === "prefix.next-pane") return this.nextPane();
    if (action[0] === "prefix.help") return this.help();
    this.close();
    run(action[0], action[1] ?? {});
  }

  render() {
    if (this.showHelp) {
      const t = theme();
      const row = (keys, label) => h_flex().h(28).flex_none().items_center().gap(12)
        .child(div().w(210).flex_none().text_color(t.accent).child(keys))
        .child(div().flex_1().child(label));
      return v_flex().id("prefix-help").track_focus(this.handle).size_full().min_h(0)
        .p(18).gap(12).bg(t.popover).text_color(t.foreground).text_size(13)
        .on_key_down((event, cx) => this.key(event, cx))
        .child(h_flex().items_center()
          .child(div().flex_1().text_size(15).font_semibold().child("Prefix shortcuts"))
          .child(div().text_color(t.dim).cursor_pointer().on_click(() => this.close()).child("Esc")))
        .child(div().text_color(t.dim).child("Press Ctrl+A, release it, then press a shortcut."))
        .child(v_flex().flex_1().min_h(0).overflow_y_scrollbar()
          .children(shortcutRows().map(({ keys, label }) => row(keys, label)))
          .child(row("Escape", "Cancel the pending prefix")));
    }
    return div()
      .id("legacy-prefix")
      .track_focus(this.handle)
      .size(1)
      .on_key_down((event, cx) => this.key(event, cx));
  }
}
