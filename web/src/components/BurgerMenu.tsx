import { Button } from "../shadcn/ui/button";
import { RxHamburgerMenu } from "react-icons/rx";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "../shadcn/ui/dropdown-menu";
import { MenuButtons } from "./MenuButtons";

export const BurgerMenu = () => {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant={"outline"}>
          <RxHamburgerMenu className="" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="m-2 grid h-auto gap-y-3 p-4">
        <MenuButtons />
      </DropdownMenuContent>
    </DropdownMenu>
  );
};
