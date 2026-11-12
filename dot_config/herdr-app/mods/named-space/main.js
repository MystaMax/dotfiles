import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, focused, spaces, theme } from "herdr";

export default class NamedSpace extends View {
  init(_props, cx) {
    const origin = focused();
    this.machine = spaces().find((space) => space.id === origin?.space)?.machine ?? "";
    this.text = "";
    this.error = "";
    this.submitted = false;
    this.input = InputState.new({ value: this.text });
    this.input.on("change", (_e, cx) => { this.text = this.input.value(); this.error = ""; cx.notify(); });
    this.input.on("submit", (_e, cx) => this.submit(cx));
    this.inputFocused = true;
    this.input.on("focus", (_e, cx) => { this.inputFocused = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.inputFocused = false; cx.notify(); });
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  submit(cx) {
    if (this.submitted) return;
    const name = this.text.trim();
    if (!name) {
      this.error = "Enter a name before creating the space.";
      this.input.focus();
      cx.notify();
      return;
    }
    this.submitted = true;
    try {
      run("space.new", { name, machine: this.machine });
    } catch (error) {
      this.submitted = false;
      this.error = String(error);
      cx.notify();
      return;
    }
    closeOverlay(props().overlay);
  }

  key(e, cx) {
    if (e.key === "escape") { closeOverlay(props().overlay); cx.stop_propagation(); }
  }

  render() {
    const t = theme();
    const label = (text) => div().pt(16).pb(7).text_size(11.5).text_color(t.dim).child(text);
    const button = (id, text, primary, action) => h_flex().id(id).h(32).px(14).items_center().rounded(8)
      .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
      .hover(s => s.opacity(0.88)).on_click(action).child(text);
    return v_flex().id("named-space").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .w_full().min_h(0).p(18).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().child("New space"))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(label("Name"))
      .child(Input.new(this.input).h(36).px(10).rounded(9).border_1().border_color(this.inputFocused ? t.accent : t.input).bg(t.background).text_size(12.8).text_color(t.foreground))
      .child(div().pt(6).text_size(11.5).text_color(t.dim).child("A name is required. Cancel creates nothing."))
      .when(Boolean(this.error), el => el.child(div().pt(6).text_size(11.5).text_color(t.ansi1).child(this.error)))
      .child(h_flex().pt(20).gap(8).justify_end()
        .child(button("pm-cancel", "Cancel", false, () => closeOverlay(props().overlay)))
        .child(button("pm-save", "Create space", true, (_event, cx) => this.submit(cx))));
  }
}
