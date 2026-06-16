import { Gtk } from "ags/gtk4";

export function Corner({
  place,
  r = 40,
  onClick,
}: {
  r?: number;
  place: "top-left" | "top-right";
  onClick?: () => void;
}) {
  return (
    <box>
      <Gtk.GestureClick onPressed={onClick} />

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
    </box>
  );
}
