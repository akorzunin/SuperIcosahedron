import { useEffect } from "react";
import Iframe from "react-iframe";

export const GodotFrame = () => {
  useEffect(() => {
    window.frames[0].stop();
  }, []);

  return (
    <div className="grid justify-items-center pt-6">
      <div className="w-max">
        <Iframe
          url="download/web/index.html"
          width="800px"
          height="450px"
          id=""
          className=""
          title="SuperIcosahedron"
          display="block"
          position="static"
          loading="lazy"
          frameBorder={0}
          allowFullScreen
        />
        <p className="flex justify-end text-primary-foreground">
          GodotFrame Latest build: version: __VERSION__ commit: __COMMIT__
        </p>
      </div>
    </div>
  );
};
