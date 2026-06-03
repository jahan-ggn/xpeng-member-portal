export function isTruthyCustomField(value) {
  return value === true || value === "t" || value === "true";
}

export function isDvlaVerified(user, groupName) {
  return user?.groups?.some((group) => group.name === groupName);
}

export function formatMemberType(value) {
  if (!value) {
    return null;
  }
  return value
    .split("_")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}
