import { Injectable, signal } from '@angular/core';
import { ApiService } from './api.service';
import { Router } from '@angular/router';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  // Using signals for modern reactive state
  currentUserSignal = signal<any>(null);

  constructor(private api: ApiService, private router: Router) {
    // On init, check if we have a token (simplified session check)
    const token = localStorage.getItem('auth_token');
    if (token) {
      // In a real app we'd validate the token here
      this.currentUserSignal.set({ token });
    }
  }

  login(userName: string, userPass: string) {
    return this.api.post<any>('/login', { userName, userPass }).pipe(
      tap(res => {
        if (res.status === 0 && res.session) {
          this.saveToken(res.session);
        }
      })
    );
  }

  register(data: any) {
    return this.api.post<any>('/registerUser', data);
  }

  // Helper for saving token manually if needed
  saveToken(token: string) {
    localStorage.setItem('auth_token', token);
    this.currentUserSignal.set({ token });
  }

  logout() {
    localStorage.removeItem('auth_token');
    this.currentUserSignal.set(null);
    this.router.navigate(['/login']);
  }
}
