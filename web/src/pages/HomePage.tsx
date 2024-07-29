import { GodotFrame } from "../components/GodotFrame";
import { LinkCard } from "../components/LinkCard";

export const HomePage = () => {
  return (
    <>
      <div>HomePage</div>
      <p className="bg-background">Title</p>
      <div className="card">
        <a href="/download/">dl link</a>
        <LinkCard />
        <GodotFrame />
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  );
};
