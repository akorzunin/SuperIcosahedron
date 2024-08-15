import { Description } from "../components/Description";
import { Footer } from "../components/Footer";
import { GodotFrame } from "../components/GodotFrame";
import { Header } from "../components/Header";

export const HomePage = () => {
  return (
    <div className="h-screen">
      <Header />
      <GodotFrame />
      <Description />
      <Footer />
    </div>
  );
};
