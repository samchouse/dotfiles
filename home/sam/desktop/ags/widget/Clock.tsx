import GLib from "gi://GLib?version=2.0";
import { Astal, type Gdk, Gtk } from "ags/gtk4";
import app from "ags/gtk4/app";
import { createComputed, createState, With } from "gnim";
import { Corner } from "./Corner";

export function Clock({
  gdkmonitor,
  toggleBackdrop,
  connectOnBackdropClick,
}: {
  gdkmonitor: Gdk.Monitor;
  toggleBackdrop: () => void;
  connectOnBackdropClick: (onClick: () => boolean) => void;
}) {
  const { TOP, RIGHT } = Astal.WindowAnchor;

  let revealerRef: Gtk.Revealer;
  let windowRef: Astal.Window;
  let calendarRef: Gtk.Calendar;

  const [calendarInfo, setCalendarInfo] = createState({
    month: GLib.DateTime.new_now_local().get_month(),
    year: GLib.DateTime.new_now_local().get_year(),
  });

  const calendarLabel = createComputed(
    () =>
      GLib.DateTime.new_local(
        calendarInfo().year,
        calendarInfo().month,
        1,
        0,
        0,
        0,
      ).format("%B %Y") ?? "",
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
        <box orientation={Gtk.Orientation.VERTICAL} class="main-box">
          <centerbox>
            <box $type="start">
              <With value={calendarLabel}>
                {(calLabel) => <label label={calLabel} />}
              </With>
            </box>

            <box $type="end" class="icon">
              <button
                onClicked={() => {
                  setCalendarInfo((info) => ({
                    month: info.month === 1 ? 12 : info.month - 1,
                    year: info.month === 1 ? info.year - 1 : info.year,
                  }));
                  calendarRef.select_day(
                    GLib.DateTime.new_local(
                      calendarInfo().year,
                      calendarInfo().month,
                      1,
                      0,
                      0,
                      0,
                    ),
                  );
                }}
              >
                chevron_left
              </button>
              <button
                onClicked={() => {
                  const today = GLib.DateTime.new_now_local();
                  setCalendarInfo({
                    month: today.get_month(),
                    year: today.get_year(),
                  });
                  calendarRef.select_day(today);
                }}
              >
                today
              </button>
              <button
                onClicked={() => {
                  setCalendarInfo((info) => ({
                    month: info.month === 12 ? 1 : info.month + 1,
                    year: info.month === 12 ? info.year + 1 : info.year,
                  }));
                  calendarRef.select_day(
                    GLib.DateTime.new_local(
                      calendarInfo().year,
                      calendarInfo().month,
                      1,
                      0,
                      0,
                      0,
                    ),
                  );
                }}
              >
                chevron_right
              </button>
            </box>
          </centerbox>

          <box>
            <Gtk.GestureClick
              propagationPhase={Gtk.PropagationPhase.CAPTURE}
              onPressed={(self) =>
                self.set_state(Gtk.EventSequenceState.CLAIMED)
              }
            />
            <Gtk.Calendar
              $={(self) => {
                calendarRef = self;

                const scrollController = new Gtk.EventControllerScroll({
                  propagationPhase: Gtk.PropagationPhase.CAPTURE,
                  flags: Gtk.EventControllerScrollFlags.VERTICAL,
                });
                scrollController.connect("scroll", () => true);

                self.add_controller(scrollController);
              }}
              widthRequest={Math.max(gdkmonitor.geometry.width * 0.2, 200)}
              showHeading={false}
            />
          </box>
        </box>
      </box>
    </revealer>
  </window>;

  return { toggleWindow };
}
