import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  keeperSidebar: [
    "index",
    {
      type: "category",
      label: "Architecture",
      collapsed: false,
      items: [
        { type: "doc", id: "architecture/index", label: "Architecture Overview" },
        { type: "doc", id: "architecture/keeper-spec", label: "Keeper Specification" },
      ],
    },
  ],
};
export default sidebars;
