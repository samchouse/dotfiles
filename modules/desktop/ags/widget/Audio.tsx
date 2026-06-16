import Wireplumber from "gi://AstalWp";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { createBinding, createComputed, For } from "gnim";
import { Corner } from "./Corner";

export function Audio({
  gdkmonitor,
  toggleBackdrop,
  connectOnBackdropClick,
}: {
  gdkmonitor: Gdk.Monitor;
  toggleBackdrop: () => void;
  connectOnBackdropClick: (onClick: () => boolean) => void;
}) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  let windowRef: Astal.Window;
  let revealerRef: Gtk.Revealer;
  let checkButtonRef: Gtk.CheckButton;

  const wp = Wireplumber.get_default();
  const { defaultSpeaker: speaker } = wp;
  const speakers = createComputed(() =>
    createBinding(wp, "audio", "speakers")().sort((a, b) =>
      a.description.localeCompare(b.description),
    ),
  );

  connectOnBackdropClick(() => {
    if (!revealerRef.revealChild) return false;
    revealerRef.revealChild = false;
    return true;
  });

  function toggleWindow() {
    if (!windowRef.visible) windowRef.visible = true;
    toggleBackdrop();
    revealerRef.revealChild = !revealerRef.revealChild;
  }

  <window
    $={(self) => {
      windowRef = self;
    }}
    gdkmonitor={gdkmonitor}
    layer={Astal.Layer.OVERLAY}
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={TOP | RIGHT}
    application={app}
    onNotifyVisible={(self) =>
      self.set_margin_top(app.get_window("bar")?.get_height() ?? 0)
    }
  >
    <Gtk.GestureClick
      onPressed={() => toggleWindow()}
      propagationPhase={Gtk.PropagationPhase.TARGET}
    />

    <revealer
      $={(self) => {
        revealerRef = self;
      }}
      vexpand={false}
      valign={Gtk.Align.START}
      onNotifyChildRevealed={(self) => {
        if (self.get_reveal_child()) return;
        windowRef.visible = false;
      }}
    >
      <box orientation={Gtk.Orientation.HORIZONTAL}>
        <Corner place="top-left" onClick={toggleWindow} />
        <box orientation={Gtk.Orientation.VERTICAL} class="main-box audio-box">
          <label label="Volume" halign={Gtk.Align.START} />
          <box>
            <slider
              value={createBinding(speaker, "volume")}
              onChangeValue={({ value }) => speaker.set_volume(value)}
              widthRequest={300}
            />
            <label
              label={createComputed(
                () =>
                  `${(createBinding(speaker, "volume")() * 100).toFixed(0)}%`,
              )}
              widthChars={5}
            />
          </box>

          <Gtk.Separator />

          <label label="Output" halign={Gtk.Align.START} />
          <box orientation={Gtk.Orientation.VERTICAL}>
            <For each={speakers}>
              {(speaker, index) => (
                <Gtk.CheckButton
                  $={(self) => {
                    if (index() === 0) checkButtonRef = self;
                    speaker.connect("notify::is-default", (s) => {
                      if (speaker.isDefault && s.deviceId === speaker.deviceId)
                        self.active = speaker.isDefault;
                    });
                  }}
                  active={speaker.isDefault}
                  label={createBinding(speaker, "description")}
                  group={checkButtonRef}
                  onToggled={(self) => {
                    if (self.active) speaker.isDefault = true;
                  }}
                />
              )}
            </For>
          </box>
        </box>
      </box>
    </revealer>
  </window>;

  return { toggleWindow };
}
