import { useState, useRef, useEffect } from "react";
import { Button } from "../shadcn/ui/button";
import { FaPlay, FaExpand, FaVolumeUp, FaVolumeMute } from "react-icons/fa";
import { useQuery } from "@tanstack/react-query";
import { getGameVersionInfo } from "../lib/versions";

interface AudioBridge {
  state?: boolean;
  volume?: number;
}
interface GodotBridge {
  setAudioState(data: AudioBridge): unknown;
}
interface WindowBridge extends Window {
  godotAudioBridge: GodotBridge;
}

export const GodotFrame = () => {
  const [showIframe, setShowIframe] = useState(false);
  const [muted, setMuted] = useState(false);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const { data: gameVersionData } = useQuery({
    queryKey: ["version-data"],
    queryFn: async () => await getGameVersionInfo(),
  });

  const handleFullscreen = () => {
    if (iframeRef.current) {
      iframeRef.current.requestFullscreen();
    }
  };

  const handleKeyDown = (event: { key: string }) => {
    if (event.key === "Escape") {
      if (document.fullscreenElement) {
        document.exitFullscreen();
      }
    }
  };

  const handleMuteToggle = () => {
    setMuted((prevMuted) => {
      const newMuted = !prevMuted;
      if (iframeRef.current && iframeRef.current.contentWindow) {
        const w = iframeRef.current.contentWindow as WindowBridge;
        w.godotAudioBridge.setAudioState({ state: prevMuted });
      }
      return newMuted;
    });
  };

  useEffect(() => {
    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, []);

  return (
    <div className="grid justify-items-center px-6 pt-6">
      <div
        className="w-screen-lg relative aspect-video min-w-[90vw]"
        style={{ maxHeight: "60vh" }}
      >
        {!showIframe && (
          <div className="absolute inset-0 flex items-center justify-center bg-muted bg-opacity-75">
            <Button onClick={() => setShowIframe(true)}>
              <FaPlay />
              &nbsp;Run
            </Button>
          </div>
        )}
        {showIframe && (
          <>
            <iframe
              src={"download/web/index.html"}
              id="iframeId"
              className="inset-0 overflow-hidden"
              height="100%"
              width="100%"
              title="SuperIcosahedron"
              allow="autoplay"
              loading="lazy"
              ref={iframeRef}
            />
            <Button
              className="absolute bottom-10 left-10"
              onClick={handleFullscreen}
            >
              <FaExpand />
              &nbsp;Fullscreen
            </Button>
            <Button
              className="absolute bottom-10 right-10"
              onClick={handleMuteToggle}
            >
              {muted ? <FaVolumeMute /> : <FaVolumeUp />}
              &nbsp;{muted ? "Unmute" : "Mute"}
            </Button>
          </>
        )}
        <p className="absolute bottom-0 right-2 text-primary-foreground">
          build: {gameVersionData?.version} commit: {gameVersionData?.commit}
        </p>
      </div>
    </div>
  );
};
