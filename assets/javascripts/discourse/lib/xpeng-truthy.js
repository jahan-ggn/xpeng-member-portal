export function isTruthyCustomField(value) {
  return value === true || value === "t" || value === "true";
}

export function isDvlaVerified(user, groupName) {
  return user?.groups?.some((group) => group.name === groupName);
}
