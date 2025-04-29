let Hooks = {};

Hooks.AuthHook = {
  mounted() {
    const name = localStorage.getItem("rps_name");
    const fp = localStorage.getItem("rps_fp");

    if (name && fp) {
      console.log("AuthHook: Sending credentials to server...");
      this.pushEvent("auth", { name, fp });
    } else {
      console.log("AuthHook: No credentials, staying here...");
      // DO NOTHING! Stay on page.
    }
  }
};

Hooks.LogoutHook = {
  mounted() {
    this.el.addEventListener("click", () => {
      console.log("Logout clicked");
      localStorage.removeItem("rps_name");
      localStorage.removeItem("rps_fp");
      window.location.replace("/");
    });
  }
};


Hooks.ScoreAnimate = {
  updated() {
    // Animate each scoreboard number individually
    ["score-player", "score-draw", "score-cpu"].forEach((id) => {
      const el = document.getElementById(id);
      if (el) {
        el.classList.remove("scale-100");
        el.classList.add("scale-125");

        setTimeout(() => {
          el.classList.remove("scale-125");
          el.classList.add("scale-100");
        }, 200); // Animate back after 200ms
      }
    });
  }
};


export default Hooks;

