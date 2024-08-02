import { FaDownload, FaGithubAlt, FaItchIo, FaSteam } from "react-icons/fa";
import { Button } from "../shadcn/ui/button";
import { ModeToggle } from "../shadcn/ui/mode-toggle";

export const Header = () => {
  return (
    <div className="flex justify-between bg-secondary p-6">
      <h2 className="mt-10 scroll-m-20 justify-items-start pb-2 text-3xl font-semibold tracking-tight text-primary-foreground transition-colors first:mt-0">
        SuperIcosahedron
      </h2>
      <div className="flex gap-3">
        <Button asChild>
          <a href="/download/">
            <FaDownload />
            &nbsp;Download
          </a>
        </Button>
        <Button asChild>
          <a
            href="https://github.com/akorzunin/SuperIcosahedron"
            target="_blank"
          >
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
      </div>
    </div>
  );
};
