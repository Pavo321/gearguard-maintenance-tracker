// const KEY = "gg_user";

// export function saveUser(user) {
//   localStorage.setItem(KEY, JSON.stringify(user));
// }

// export function getUser() {
//   const raw = localStorage.getItem(KEY);
//   if (!raw) return null;
//   try { return JSON.parse(raw); } catch { return null; }
// }

// export function logout() {
//   localStorage.removeItem(KEY);
// }
export function getUser() {
  return { id: 1, name: "Demo User", role: "ADMIN" };
}
export function saveUser() {}
export function logout() {}
