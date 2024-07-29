import { Footer } from "../components/Footer";
import { GodotFrame } from "../components/GodotFrame";
import { Header } from "../components/Header";

export const HomePage = () => {
  return (
    <div className="flex-col justify-center">
      <Header />
      <GodotFrame />
      <Footer />
    </div>
  );
};
