import { FaTelegram } from "react-icons/fa";
import { BiLogoGmail } from "react-icons/bi";

export const Footer = () => {
  return (
    <div className="fixed inset-x-0 bottom-0 bg-secondary">
      <div className="mx-auto flex max-w-4xl items-center justify-between p-6 text-primary-foreground">
        <div className="text-sm">
          2024 —{" "}
          <a
            href="https://github.com/akorzunin"
            target="_blank"
            rel="noopener noreferrer"
          >
            @akorzunin
          </a>
        </div>
        <div className="flex items-center gap-3">
          <p>Contacts: </p>
          <a href="https://t.me/akorzunin" target="_blank">
            <FaTelegram />
          </a>
          <a href="mailto:akorzunin123@gmail.com" target="_blank">
            <BiLogoGmail />
          </a>
        </div>
      </div>
    </div>
  );
};
