import { Astal, Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";

export function Backdrop(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT } = Astal.WindowAnchor;

  let boxRef: Gtk.Box;
  let windowRef: Astal.Window;
  let gestureRef: Gtk.GestureClick;

  <window
    $={(self) => {
      windowRef = self;
    }}
    gdkmonitor={gdkmonitor}
    layer={Astal.Layer.TOP}
    exclusivity={Astal.Exclusivity.IGNORE}
    anchor={TOP | LEFT}
    application={app}
    widthRequest={gdkmonitor.geometry.width}
    heightRequest={gdkmonitor.geometry.height}
    onNotifyVisible={() =>
      boxRef.set_margin_top(app.get_window("bar")?.get_height() ?? 0)
    }
  >
    <Gtk.GestureClick
      $={(self) => {
        gestureRef = self;
      }}
      button={Gdk.BUTTON_PRIMARY}
    />

    <box
      class="backdrop"
      $={(self) => {
        boxRef = self;
      }}
    />
  </window>;

  return {
    toggleVisible: () => {
      windowRef.visible = !windowRef.visible;
    },
    connectOnClick: (onClick: () => boolean) => {
      gestureRef.connect("pressed", () => {
        if (onClick() === true) windowRef.visible = false;
      });
    },
  };
}
