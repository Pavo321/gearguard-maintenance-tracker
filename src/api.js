// export const API_BASE = "http://localhost:5000/api";

// async function parseRes(res) {
//   let data = null;
//   try { data = await res.json(); } catch { data = null; }
//   if (!res.ok) {
//     const msg = (data && data.message) ? data.message : `Request failed (${res.status})`;
//     throw new Error(msg);
//   }
//   return data;
// }

// export async function apiGet(path) {
//   const res = await fetch(API_BASE + path);
//   return parseRes(res);
// }

// export async function apiPost(path, body) {
//   const res = await fetch(API_BASE + path, {
//     method: "POST",
//     headers: { "Content-Type": "application/json" },
//     body: JSON.stringify(body || {})
//   });
//   return parseRes(res);
// }

// export async function apiPut(path, body) {
//   const res = await fetch(API_BASE + path, {
//     method: "PUT",
//     headers: { "Content-Type": "application/json" },
//     body: JSON.stringify(body || {})
//   });
//   return parseRes(res);
// }

// export async function apiDelete(path) {
//   const res = await fetch(API_BASE + path, { method: "DELETE" });
//   return parseRes(res);
// }
// MOCK API — frontend only

export async function apiGet(path) {
  if (path === "/dashboard/summary") {
    return {
      critical_equipment: 2,
      technician_load_percent: 68,
      open_requests: 4,
      overdue_requests: 1
    };
  }

  if (path === "/dashboard/recent-requests") {
    return [
      {
        id: 1,
        subject: "Laptop issue",
        employee: "Abigail Peterson",
        technician: "Aka Foster",
        category: "Computers",
        stage: "NEW_REQUEST",
        company: "My Company"
      }
    ];
  }

  if (path === "/equipment") {
    return [
      {
        id: 1,
        name: "Acer Laptop",
        employee: "Abigail Peterson",
        department: "Admin",
        serial_number: "MT/122/11112222",
        technician: "Aka Foster",
        category: "Computers",
        company: "My Company"
      }
    ];
  }

  if (path === "/workcenters") {
    return [
      {
        id: 1,
        name: "Assembly 1",
        code: "A1",
        tag: "ASSEMBLY",
        alternative_workcenters: "Drill 1",
        cost_per_hour: 100,
        capacity: 1,
        time_efficiency: 100,
        oee_target: 34.59
      }
    ];
  }

  if (path === "/teams") {
    return [
      {
        id: 1,
        name: "Internal Maintenance",
        members: "Aka Foster, Marc Demo",
        company: "My Company"
      }
    ];
  }

  if (path === "/requests/meta") {
    return {
      equipment: [{ id: 1, name: "Acer Laptop", serial_number: "MT/122" }],
      workcenters: [{ id: 1, name: "Assembly 1" }],
      teams: [{ id: 1, name: "Internal Maintenance" }],
      techs: [{ id: 1, name: "Aka Foster" }],
      categories: [{ id: 1, name: "Computers" }]
    };
  }

  return [];
}

export async function apiPost() {
  return { message: "Saved (mock)" };
}

export async function apiPut() {
  return { message: "Updated (mock)" };
}

export async function apiDelete() {
  return { message: "Deleted (mock)" };
}
