import { useState } from "react";
import Iframe from "react-iframe";
import { Button } from "../shadcn/ui/button";
import { FaPlay } from "react-icons/fa";
import { useQuery } from "@tanstack/react-query";
import { getGameVersionInfo } from "../lib/versions";

export const GodotFrame = () => {
  const [showIframe, setShowIframe] = useState(false);
  const { data: gameVersionData } = useQuery({
    queryKey: ["version-data"],
    queryFn: async () => await getGameVersionInfo(),
  });
  return (
    <div className="grid justify-items-center px-6 pt-6">
      <div className="w-screen-lg relative aspect-video min-h-[70vh]">
        {!showIframe && (
          <div className="absolute inset-0 flex items-center justify-center bg-muted bg-opacity-75">
            <Button onClick={() => setShowIframe(true)}>
              <FaPlay />
              &nbsp;Run
            </Button>
          </div>
        )}
        {showIframe && (
          <Iframe
            url={import.meta.env.DEV ? "/download/" : "download/web/index.html"}
            id=""
            className="inset-0"
            height="100%"
            width="100%"
            title="SuperIcosahedron"
            display="initial"
            loading="lazy"
            scrolling="no"
            frameBorder={0}
          />
        )}
        <p className="absolute bottom-0 right-2 text-primary-foreground">
          build: {gameVersionData?.version} commit: {gameVersionData?.commit}
        </p>
      </div>
    </div>
  );
};
