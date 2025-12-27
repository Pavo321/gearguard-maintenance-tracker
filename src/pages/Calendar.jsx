import React, { useEffect, useState } from "react";
import { apiGet } from "../api.js";
import { useNavigate } from "react-router-dom";

export default function Calendar() {
  const nav = useNavigate();
  const [rows, setRows] = useState([]);

  useEffect(() => {
    (async () => {
      const list = await apiGet("/requests");
      setRows(list.filter(x => x.scheduled_at));
    })().catch(console.error);
  }, []);

  return (
    <div>
      <div className="topbar">
        <h2 className="topbar-title">Maintenance Calendar</h2>
      </div>
      <div className="content-wrapper">
        <p className="small" style={{ marginBottom: "1.5rem" }}>
          Simple calendar placeholder (like your wireframe). Later you can plug FullCalendar.
          For now it lists scheduled requests.
        </p>

        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Subject</th>
                <th>Scheduled At</th>
                <th>Stage</th>
                <th>Type</th>
              </tr>
            </thead>
            <tbody>
              {rows.map(r => (
                <tr key={r.id} onClick={() => nav(`/requests?open=${r.id}`)}>
                  <td>{r.subject}</td>
                  <td>{r.scheduled_at}</td>
                  <td>{r.stage}</td>
                  <td>{r.maintenance_for}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
