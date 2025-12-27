import React from "react";
import { Routes, Route, Navigate } from "react-router-dom";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import Layout from "./components/Layout.jsx";

import Login from "./pages/Login.jsx";
import Signup from "./pages/Signup.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import EquipmentList from "./pages/EquipmentList.jsx";
import EquipmentForm from "./pages/EquipmentForm.jsx";
import Teams from "./pages/Teams.jsx";
import WorkCenters from "./pages/WorkCenters.jsx";
import Requests from "./pages/Requests.jsx";
import Calendar from "./pages/Calendar.jsx";

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/dashboard" replace />} />
      <Route path="/login" element={<Login />} />
      <Route path="/signup" element={<Signup />} />

      <Route element={<ProtectedRoute />}>
        <Route element={<Layout />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/equipment" element={<EquipmentList />} />
          <Route path="/equipment/new" element={<EquipmentForm mode="new" />} />
          <Route path="/equipment/:id" element={<EquipmentForm mode="edit" />} />
          <Route path="/teams" element={<Teams />} />
          <Route path="/workcenters" element={<WorkCenters />} />
          <Route path="/requests" element={<Requests />} />
          <Route path="/calendar" element={<Calendar />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/dashboard" replace />} />
    </Routes>
  );
}
