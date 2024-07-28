import { useEffect } from "react";
import Iframe from "react-iframe";

export const GodotFrame = () => {
  useEffect(() => {
    window.frames[0].stop();
  }, []);

  return (
    <div>
      GodotFrame
      <Iframe
        url="download/web/index.html"
        width="800px"
        height="450px"
        id=""
        className=""
        title="SuperIcosahedron"
        display="block"
        position="relative"
        loading="lazy"
        frameBorder={0}
        allowFullScreen
      />
    </div>
  );
};
