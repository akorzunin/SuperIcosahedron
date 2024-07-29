import { Button } from "../shadcn/ui/button";
import { ModeToggle } from "../shadcn/ui/mode-toggle";

export const Header = () => {
  return (
    <div className="flex justify-between p-4">
      <h2 className="mt-10 scroll-m-20 justify-items-start pb-2 text-3xl font-semibold tracking-tight text-primary-foreground transition-colors first:mt-0">
        SuperIcosahedron
      </h2>
      <div className="flex gap-3">
        <Button asChild>
          <a href="/download/">download</a>
        </Button>
        <Button>source code</Button>
        <Button disabled>steam</Button>
        <Button disabled>itch</Button>
        <ModeToggle />
      </div>
    </div>
  );
};
