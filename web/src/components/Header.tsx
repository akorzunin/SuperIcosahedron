import { Button } from "../shadcn/ui/button";
import { ModeToggle } from "../shadcn/ui/mode-toggle";

export const Header = () => {
  return (
    <>
      <Button>download</Button>
      <Button>source code</Button>
      <Button>steam</Button>
      <Button>itch</Button>
      <ModeToggle />
    </>
  );
};
