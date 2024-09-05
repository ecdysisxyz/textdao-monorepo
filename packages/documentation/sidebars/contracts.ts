import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  contractsSidebar: [
    "index",
    {
      type: "category",
      label: "Architecture",
      collapsed: false,
      items: [
        { type: "doc", id: "architecture/index", label: "Architecture Overview" },
        { type: "doc", id: "architecture/hubdao-spec", label: "HubDAO Specification" },
        { type: "doc", id: "architecture/textdao-spec", label: "TextDAO Specification" },
        { type: "doc", id: "architecture/contract-relationship", label: "Contract Relationships" },
      ],
    },
    {
      type: "category",
      label: "Guides",
      collapsed: false,
      items: [
        { type: "doc", id: "guides/index", label: "Guides Overview" },
        { type: "doc", id: "guides/contract-interaction", label: "Contract Interaction" },
      ],
    },
    {
      type: "category",
      label: "Development",
      collapsed: false,
      items: [
        { type: "doc", id: "development/index", label: "Development Overview" },
        { type: "doc", id: "development/coding-standards", label: "Coding Standards" },
        { type: "doc", id: "development/mc-devkit-usage", label: "MC DevKit Usage" },
        { type: "doc", id: "development/meta-contract-spec", label: "Meta Contract Specification" },
        { type: "doc", id: "development/test-strategy", label: "Testing Strategy" },
      ],
    },
  ],
};

export default sidebars;
