import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  frontendSidebar: [
    "index",
    {
      type: "category",
      label: "Architecture",
      collapsed: false,
      items: [
        { type: "doc", id: "architecture/index", label: "Architecture Overview" },
        { type: "doc", id: "architecture/ui-components", label: "UI Components" },
      ],
    },
    {
      type: "category",
      label: "Development",
      collapsed: false,
      items: [
        { type: "doc", id: "development/index", label: "Development Overview" },
        // { type: "doc", id: "development/coding-standards", label: "Coding Standards" },
        { type: "doc", id: "development/test-strategy", label: "Test Strategy" },
        { type: "doc", id: "development/ui-component-development", label: "UI Component Development" },
      ],
    },
  ],
};
export default sidebars;
