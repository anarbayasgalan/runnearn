import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
    const router = inject(Router);

    return next(req).pipe(
        catchError((error: HttpErrorResponse) => {
            let message = 'An unexpected error occurred.';

            if (error.status === 0) {
                message = 'Cannot reach the server. Check your connection.';
            } else if (error.status === 401 || error.status === 403) {
                // Session expired or unauthorized — clear token and redirect
                localStorage.removeItem('auth_token');
                router.navigate(['/login'], {
                    queryParams: { reason: 'session_expired' }
                });
                message = 'Session expired. Please log in again.';
            } else if (error.status === 400) {
                message = error.error?.responseDesc || error.error?.message || 'Invalid request.';
            } else if (error.status === 404) {
                message = 'Resource not found.';
            } else if (error.status === 500) {
                message = error.error?.responseDesc || 'Server error. Please try again later.';
            } else if (error.error?.responseDesc) {
                message = error.error.responseDesc;
            }

            // Re-throw with a friendly message attached
            return throwError(() => ({ ...error, friendlyMessage: message }));
        })
    );
};
