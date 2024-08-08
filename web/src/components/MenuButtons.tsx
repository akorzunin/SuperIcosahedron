import { Button } from "../shadcn/ui/button";
import { FaDownload, FaGithubAlt, FaSteam, FaItchIo } from "react-icons/fa";
import { ModeToggle } from "../shadcn/ui/mode-toggle";

export const MenuButtons = () => {
  return (
    <>
      <Button asChild>
        <a href="/download/">
          <FaDownload />
          &nbsp;Download
        </a>
      </Button>
      <Button asChild>
        <a href="https://github.com/akorzunin/SuperIcosahedron" target="_blank">
          <FaGithubAlt />
          &nbsp;Source code
        </a>
      </Button>
      <Button disabled>
        <FaSteam />
        &nbsp;Steam
      </Button>
      <Button disabled>
        <FaItchIo />
        &nbsp;Itch
      </Button>
      <ModeToggle />
    </>
  );
};
