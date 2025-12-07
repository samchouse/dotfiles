import Hyprland from "gi://AstalHyprland";
import Tray from "gi://AstalTray";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date '+%-I:%M %p'");
  const date = createPoll("", 1000, "date '+%a %b %-d'");
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
  const _hyprland = Hyprland.get_default();
  const _tray = Tray.get_default();

  const [_, onClick] = ControlCenter(gdkmonitor);

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssName="centerbox">
        <box $type="start" hexpand={false}>
          <button
            onClicked={() => execAsync("echo hello").then(console.log)}
            hexpand
            halign={Gtk.Align.CENTER}
          >
            <label label="Welcome to AGS!" />
          </button>
        </box>
        <box $type="center">
          <button class="circular" />
          <button class="circular" />
          <button class="circular" />
          <button class="circular" />
          <button class="circular" />
        </box>
        <box $type="end" hexpand={false} halign={Gtk.Align.END} spacing={0}>
          <label class="icon" label="volume_down" />
          <box spacing={8}>
            <label label={date} />
            <label label={time} />
          </box>
          <button onClicked={onClick}>
            <label label="power_settings_new" class="icon" />
          </button>
        </box>
      </centerbox>
    </window>
  );
}

export function ControlCenter(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  let revealerRef: Gtk.Revealer;
  let windowRef: Astal.Window;

  function onClick() {
    if (windowRef.is_visible()) revealerRef.set_reveal_child(false);
    else {
      windowRef.set_visible(true);
      revealerRef.set_reveal_child(true);
    }
  }

  return [
    <window
      $={(self) => {
        windowRef = self;
      }}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={TOP | RIGHT}
      application={app}
      onNotifyVisible={(self) =>
        self.set_margin_top(app.get_window("bar")?.get_height() ?? 0)
      }
    >
      <revealer
        $={(self) => {
          revealerRef = self;
        }}
        vexpand={false}
        valign={Gtk.Align.START}
        onNotifyChildRevealed={(self) => {
          if (self.get_reveal_child()) return;
          windowRef.set_visible(false);
        }}
      >
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <InverseCorner place="top-left" />
          <Gtk.Calendar />
        </box>
      </revealer>
    </window>,
    onClick,
  ] as const;
}

interface InverseCornerProps {
  r?: number;
  place: "top-left" | "top-right" | "bottom-left" | "bottom-right";
}

export const InverseCorner = ({ place, r = 40 }: InverseCornerProps) => {
  return (
    <drawingarea
      vexpand={false}
      valign={Gtk.Align.START}
      widthRequest={r}
      heightRequest={r}
      $={(self) => {
        self.set_draw_func((_z, cr, width, height) => {
          switch (place) {
            case "top-left":
              cr.moveTo(width, height);
              cr.lineTo(width, 0);
              cr.lineTo(0, 0);
              cr.curveTo(
                width / 2,
                height / 2 - Math.ceil(height / 2),
                width / 2 + Math.ceil(width / 2),
                height / 2,
                width,
                height,
              );
              break;
            case "top-right":
              cr.moveTo(0, height);
              cr.lineTo(0, 0);
              cr.lineTo(width, 0);
              cr.curveTo(
                width / 2,
                height / 2 - Math.ceil(height / 2),
                width / 2 - Math.ceil(width / 2),
                height / 2,
                0,
                height,
              );
              break;
          }

          cr.setSourceRGB(0.04, 0.04, 0.04);
          cr.fill();
        });
      }}
    />
  );
};
