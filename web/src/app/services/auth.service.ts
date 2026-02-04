import { Injectable, signal } from '@angular/core';
import { ApiService } from './api.service';
import { Router } from '@angular/router';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  currentUserSignal = signal<any>(null);

  constructor(private api: ApiService, private router: Router) {
    const token = localStorage.getItem('auth_token');
    if (token) {
      this.currentUserSignal.set({ token });
    }
  }

  login(userName: string, userPass: string) {
    return this.api.post<any>('/login', { userName, userPass }).pipe(
      tap(res => {
        if (res.responseCode === 0 && res.session) {
          this.saveToken(res.session);
        }
      })
    );
  }

  register(data: any) {
    return this.api.post<any>('/registerUser', data).pipe(
      tap(res => {
        if (res.responseCode === 0 && res.session) {
          this.saveToken(res.session);
        }
      })
    );
  }

  updateCompany(data: any) {
    const token = localStorage.getItem('auth_token');
    console.log('UpdateCompany - Token exists:', !!token, 'Token:', token?.substring(0, 20) + '...');
    return this.api.post<any>('/updateCompany', data);
  }

  getCurrentUser() {
    return this.api.get<any>('/home');
  }

  getCompany() {
    return this.api.get<any>('/company');
  }

  createToken(data: any) {
    return this.api.post<any>('/token/generate', data);
  }

  redeemToken(data: any) {
    return this.api.post<any>('/token/redeem', data);
  }

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
