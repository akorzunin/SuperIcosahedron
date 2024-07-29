import { GodotFrame } from "../components/GodotFrame";

export const HomePage = () => {
  return (
    <>
      <div>HomePage</div>
      <p className="bg-sky-200">Title</p>
      <div className="card">
        <a href="/download/">dl link</a>
        <GodotFrame />
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  );
};
