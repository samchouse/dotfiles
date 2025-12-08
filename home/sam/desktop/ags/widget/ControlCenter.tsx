import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { Corner } from "./Corner";

export function ControlCenter({
  gdkmonitor,
  toggleBackdrop,
  connectOnBackdropClick,
}: {
  gdkmonitor: Gdk.Monitor;
  toggleBackdrop: () => void;
  connectOnBackdropClick: (onClick: () => void) => void;
}) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  let revealerRef: Gtk.Revealer;
  let windowRef: Astal.Window;

  connectOnBackdropClick(() => {
    if (revealerRef.revealChild) revealerRef.revealChild = false;
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
    <Gtk.GestureClick onPressed={() => toggleWindow()} />

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
        <Corner place="top-left" />
        <box>
          <Gtk.GestureClick
            onPressed={(self) => self.set_state(Gtk.EventSequenceState.CLAIMED)}
          />
          <Gtk.Calendar />
        </box>
      </box>
    </revealer>
  </window>;

  return { toggleWindow };
}
