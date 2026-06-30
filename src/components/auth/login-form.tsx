"use client";

import { useActionState } from "react";

import { loginAdmin, type LoginState } from "@/actions/auth";

const initialState: LoginState = {};

export function LoginForm() {
  const [state, formAction, pending] = useActionState(loginAdmin, initialState);

  return (
    <form action={formAction} className="auth-form">
      <div className="field-group">
        <label htmlFor="email">Email</label>
        <input autoComplete="email" id="email" name="email" required type="email" />
      </div>

      <div className="field-group">
        <label htmlFor="password">Contraseña</label>
        <input
          autoComplete="current-password"
          id="password"
          name="password"
          required
          type="password"
        />
      </div>

      {state.message ? (
        <p aria-live="polite" className="form-error" role="alert">
          {state.message}
        </p>
      ) : null}

      <button className="primary-button" disabled={pending} type="submit">
        {pending ? "Ingresando…" : "Ingresar"}
      </button>
    </form>
  );
}
