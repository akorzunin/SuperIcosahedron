import { Button } from "../shadcn/ui/button";

export const Footer = () => {
  return (
    <div className="fixed inset-x-0 bottom-0 bg-secondary">
      <div className="mx-auto flex max-w-4xl justify-between p-6">
        <Button>2024 - akorzunin</Button>
        <Button>contacts</Button>
      </div>
    </div>
  );
};
