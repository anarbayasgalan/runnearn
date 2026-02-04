import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export class DashboardComponent implements OnInit {

  currentUser = signal<any>(null);
  company = signal<any>(null);
  loading = signal(true);
  error = signal<string | null>(null);

  // Token management
  showRedeemModal = signal(false);
  showCreateModal = signal(false);
  redeemCode = '';
  redeemResult = signal<any>(null);
  createdToken = signal<any>(null);
  tokenLoading = signal(false);

  constructor(private auth: AuthService, private router: Router) { }

  ngOnInit() {
    this.loadDashboardData();
  }

  loadDashboardData() {
    this.loading.set(true);
    this.error.set(null);

    // Load current user
    this.auth.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser.set(user);

        // Load company details
        this.auth.getCompany().subscribe({
          next: (company) => {
            this.company.set(company);
            this.loading.set(false);
          },
          error: (err) => {
            console.error('Error loading company:', err);
            this.error.set('Failed to load company details');
            this.loading.set(false);
          }
        });
      },
      error: (err) => {
        console.error('Error loading user:', err);
        this.error.set('Failed to load user data');
        this.loading.set(false);
      }
    });
  }

  openRedeemModal() {
    this.showRedeemModal.set(true);
    this.redeemCode = '';
    this.redeemResult.set(null);
  }

  closeRedeemModal() {
    this.showRedeemModal.set(false);
    this.redeemCode = '';
    this.redeemResult.set(null);
  }

  redeemToken() {
    if (!this.redeemCode.trim()) {
      return;
    }

    this.tokenLoading.set(true);
    this.auth.redeemToken({ token: this.redeemCode }).subscribe({
      next: (result) => {
        this.redeemResult.set(result);
        this.tokenLoading.set(false);
      },
      error: (err) => {
        console.error('Error redeeming token:', err);
        this.redeemResult.set({
          responseCode: 1,
          responseDesc: err.error?.responseDesc || 'Failed to redeem token'
        });
        this.tokenLoading.set(false);
      }
    });
  }

  openCreateModal() {
    this.showCreateModal.set(true);
    this.createdToken.set(null);
  }

  closeCreateModal() {
    this.showCreateModal.set(false);
    this.createdToken.set(null);
  }

  createToken() {
    this.tokenLoading.set(true);
    this.auth.createToken({ points: 10 }).subscribe({
      next: (result) => {
        this.createdToken.set(result);
        this.tokenLoading.set(false);
      },
      error: (err) => {
        console.error('Error creating token:', err);
        this.createdToken.set({
          responseCode: 1,
          responseDesc: err.error?.responseDesc || 'Failed to create token'
        });
        this.tokenLoading.set(false);
      }
    });
  }

  logout() {
    this.auth.logout();
  }
}
