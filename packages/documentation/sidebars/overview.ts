import type { SidebarsConfig } from "@docusaurus/plugin-content-docs";

const sidebars: SidebarsConfig = {
  overviewSidebar: [
    "index",
    {
      type: "category",
      label: "Project Overview",
      collapsed: false,
      items: [
        { type: "doc", id: "project-structure", label: "Project Structure" },
        { type: "doc", id: "glossary", label: "Glossary" },
        { type: "doc", id: "documentation-guidelines", label: "Documentation Guidelines" },
        { type: "doc", id: "versioning", label: "Versioning" },
      ],
    },
  ],
};
export default sidebars;
