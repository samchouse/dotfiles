import app from "ags/gtk4/app";
import style from "./style.scss";
import Bar from "./widget/Bar";
import { Osd } from "./widget/Osd";

app.start({
  css: style,
  main() {
    app.get_monitors().map(Bar);
    app.get_monitors().map(Osd);
  },
});
