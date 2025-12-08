import AstalTray from "gi://AstalTray";
import Gio from "gi://Gio?version=2.0";
import { Gdk, Gtk } from "ags/gtk4";
import { createBinding, createComputed, For } from "gnim";
import { readConfig } from "../utils";
import { Corner } from "./Corner";

export function Tray({
  toggleBackdrop,
  connectOnBackdropClick,
}: {
  toggleBackdrop: () => void;
  connectOnBackdropClick: (onClick: () => void) => void;
}) {
  const config = readConfig();
  const tray = AstalTray.get_default();

  let revealerRef: Gtk.Revealer;
  let popoverRef: Gtk.Popover;

  const rawItems = createBinding(tray, "items");
  const items = createComputed(() => {
    config.version();
    return rawItems().map(
      (item) => [item, undefined as unknown as Gtk.PopoverMenu] as const,
    );
  });

  const init = (pop: Gtk.PopoverMenu, item: AstalTray.TrayItem) => {
    const menu = new Gio.Menu();
    menu.append_section(null, item.menuModel);

    const extras = new Gio.Menu();
    extras.append(
      config.pinnedTray.has(item.id) ? "Unpin" : "Pin",
      "pin.toggle",
    );
    menu.append_section(null, extras);

    pop.menuModel = menu;
    pop.insert_action_group("dbusmenu", item.actionGroup);
    item.connect("notify::action-group", () => {
      pop.insert_action_group("dbusmenu", item.actionGroup);
    });

    const pinAction = new Gio.SimpleAction({
      name: "toggle",
    });
    pinAction.connect("activate", () => {
      const id = item.tooltipText || item.title || item.id;

      if (config.pinnedTray.has(id)) config.pinnedTray.delete(id);
      else config.pinnedTray.add(id);

      config.write();
    });

    const extraActionGroup = new Gio.SimpleActionGroup();
    extraActionGroup.add_action(pinAction);
    pop.insert_action_group("pin", extraActionGroup);
  };

  connectOnBackdropClick(() => {
    if (revealerRef.revealChild) revealerRef.revealChild = false;
  });

  function toggleMore() {
    if (!revealerRef.revealChild) popoverRef.popup();
    toggleBackdrop();
    revealerRef.revealChild = !revealerRef.revealChild;
  }

  return (
    <box class="tray">
      <box>
        <For each={items}>
          {([item, pop]) => (
            <box
              visible={config.pinnedTray.has(
                item.tooltipText || item.title || item.id,
              )}
            >
              <button onClicked={() => item.activate(0, 0)}>
                <Gtk.GestureClick
                  button={Gdk.BUTTON_SECONDARY}
                  onPressed={() => {
                    item.about_to_show();
                    pop.popup();
                  }}
                />

                <image gicon={createBinding(item, "gicon")} pixelSize={20} />
              </button>
              <Gtk.PopoverMenu
                $={(self) => {
                  pop = self;
                  init(self, item);
                }}
                hasArrow={false}
              />
            </box>
          )}
        </For>
      </box>

      <box>
        <Gtk.GestureClick onPressed={toggleMore} />

        <label label="More" />

        <popover
          $={(self) => {
            popoverRef = self;
          }}
          hasArrow={false}
          autohide={false}
        >
          <Gtk.GestureClick
            onPressed={(self, _, x, y) => {
              const widget = self
                .get_widget()
                ?.pick(x, y, Gtk.PickFlags.DEFAULT);
              if (widget instanceof Gtk.Button || widget instanceof Gtk.Image)
                return;

              toggleMore();
            }}
          />

          <revealer
            $={(self) => {
              revealerRef = self;
            }}
            vexpand={false}
            valign={Gtk.Align.START}
            onNotifyChildRevealed={(self) => {
              if (self.revealChild) return;
              popoverRef.popdown();
            }}
          >
            <box>
              <Corner place="top-left" r={20} />

              <box class="icons">
                <For each={items}>
                  {([item, pop]) => (
                    <box
                      visible={
                        !config.pinnedTray.has(
                          item.tooltipText || item.title || item.id,
                        )
                      }
                    >
                      <button
                        onClicked={() => {
                          toggleMore();
                          item.activate(0, 0);
                        }}
                      >
                        <Gtk.GestureClick
                          button={Gdk.BUTTON_SECONDARY}
                          onPressed={() => {
                            item.about_to_show();
                            pop.popup();
                          }}
                        />

                        <image
                          gicon={createBinding(item, "gicon")}
                          pixelSize={20}
                        />
                      </button>
                      <Gtk.PopoverMenu
                        $={(self) => {
                          pop = self;
                          init(self, item);
                        }}
                        hasArrow={false}
                        onHide={toggleMore}
                      />
                    </box>
                  )}
                </For>
              </box>

              <Corner place="top-right" r={20} />
            </box>
          </revealer>
        </popover>
      </box>
    </box>
  );
}
