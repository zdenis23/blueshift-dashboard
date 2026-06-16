import createNextIntlPlugin from "next-intl/plugin";
import redirects from "./redirects.mjs";

const nextConfig = {
  poweredByHeader: false,
  async redirects() {
    return redirects;
  },
};

const withNextIntl = createNextIntlPlugin();
export default withNextIntl(nextConfig);
