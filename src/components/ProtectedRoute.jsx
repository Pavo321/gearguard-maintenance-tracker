import React from "react";
import { Navigate, Outlet } from "react-router-dom";
import { getUser } from "../auth.js";

export default function ProtectedRoute() {
  const u = getUser();
  if (!u) return <Navigate to="/login" replace />;
  return <Outlet />;
}
