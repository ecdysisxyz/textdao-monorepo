import type * as Preset from "@docusaurus/preset-classic";
import type { Config } from "@docusaurus/types";
import { themes as prismThemes } from "prism-react-renderer";

const config: Config = {
  title: "TextDAO Documentation",
  tagline: "Decentralized Collaborative Text Management",
  favicon: "img/favicon.ico",

  // Set the production url of your site here
  url: "https://textdao-docs.ecdysis.xyz",
  baseUrl: "/",

  // GitHub pages deployment config.
  organizationName: "ecdysisxyz",
  projectName: "textdao-monorepo",

  onBrokenLinks: "warn",
  onBrokenMarkdownLinks: "warn",

  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      {
        docs: {
          routeBasePath: "/",
          editUrl: "https://github.com/ecdysisxyz/textdao-monorepo/tree/main/packages/documentation/",
        },
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  plugins: [
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "overview",
        path: "../../docs",
        routeBasePath: "overview",
        sidebarPath: require.resolve("./sidebars/overview.ts"),
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "contracts",
        path: "../contracts/docs",
        routeBasePath: "contracts",
        sidebarPath: require.resolve("./sidebars/contracts.ts"),
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "subgraph",
        path: "../subgraph/docs",
        routeBasePath: "subgraph",
        sidebarPath: require.resolve("./sidebars/subgraph.js"),
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "frontend",
        path: "../frontend/docs",
        routeBasePath: "frontend",
        sidebarPath: require.resolve("./sidebars/frontend.js"),
      },
    ],
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "keeper",
        path: "../keeper/docs",
        routeBasePath: "keeper",
        sidebarPath: require.resolve("./sidebars/keeper.js"),
      },
    ],
  ],

  markdown: {
    mermaid: true,
  },
  themes: ["@docusaurus/theme-mermaid"],

  themeConfig: {
    image: "img/docusaurus-social-card.jpg", // TODO
    navbar: {
      title: "TextDAO Docs",
      logo: {
        alt: "TextDAO Logo",
        src: "img/logo.svg",
      },
      items: [
        {
          type: "doc",
          docId: "index",
          docsPluginId: "overview",
          position: "left",
          label: "Overview",
        },
        {
          type: "doc",
          docId: "index",
          docsPluginId: "contracts",
          position: "left",
          label: "Contracts",
        },
        {
          type: "doc",
          docId: "index",
          docsPluginId: "subgraph",
          position: "left",
          label: "Subgraph",
        },
        {
          type: "doc",
          docId: "index",
          docsPluginId: "frontend",
          position: "left",
          label: "Frontend",
        },
        {
          href: "https://github.com/ecdysisxyz/textdao-monorepo",
          label: "GitHub",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Packages",
          items: [
            {
              label: "Contracts",
              to: "/contracts",
            },
            {
              label: "Subgraph",
              to: "/subgraph",
            },
            {
              label: "Frontend",
              to: "/frontend",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "Stack Overflow",
              href: "https://stackoverflow.com/questions/tagged/textdao",
            },
            {
              label: "X",
              href: "https://x.com/ecdysis_xyz",
            },
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "GitHub",
              href: "https://github.com/ecdysisxyz/textdao-monorepo",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} TextDAO Project. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ["solidity"],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
