import { BurgerMenu } from "./BurgerMenu";
import { MenuButtons } from "./MenuButtons";

export const Header = () => {
  return (
    <div className="flex items-center justify-between bg-secondary p-6">
      <h2 className="scroll-m-20 justify-items-start text-3xl font-semibold tracking-tight text-primary-foreground transition-colors first:mt-0">
        SuperIcosahedron
      </h2>
      <div className="hidden gap-3 md:flex">
        <MenuButtons />
      </div>
      <div className="flex md:hidden">
        <BurgerMenu />
      </div>
    </div>
  );
};
