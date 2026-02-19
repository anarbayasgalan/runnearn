import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
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
  redeemPassword = '';
  redeemResult = signal<any>(null);
  createdToken = signal<any>(null);
  tokenLoading = signal(false);
  tokenForm: FormGroup;
  tokens = signal<any[]>([]);

  constructor(private auth: AuthService, private router: Router, private fb: FormBuilder) {
    this.tokenForm = this.fb.group({
      expireDate: ['', Validators.required],
      price: ['', Validators.required],
      challenge: ['', Validators.required],
      quantity: [1, [Validators.required, Validators.min(1), Validators.max(100)]],
      requiredDistance: [null],
      userPass: ['', Validators.required]
    });
  }

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

            // Load tokens
            this.loadTokens();

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

  loadTokens() {
    this.auth.getTokens().subscribe({
      next: (tokens) => {
        this.tokens.set(Array.isArray(tokens) ? tokens : []);
      },
      error: (err) => {
        console.error('Error loading tokens:', err);
        this.tokens.set([]);
      }
    });
  }

  openRedeemModal() {
    this.showRedeemModal.set(true);
    this.redeemCode = '';
    this.redeemPassword = '';
    this.redeemResult.set(null);
  }

  closeRedeemModal() {
    this.showRedeemModal.set(false);
    this.redeemCode = '';
    this.redeemPassword = '';
    this.redeemResult.set(null);
  }

  redeemToken() {
    if (!this.redeemCode.trim() || !this.redeemPassword.trim()) {
      return;
    }

    this.tokenLoading.set(true);
    this.auth.redeemToken({
      token: this.redeemCode,
      userPass: this.redeemPassword
    }).subscribe({
      next: (result) => {
        this.redeemResult.set(result);
        this.tokenLoading.set(false);


        if (result.responseCode === 0) {
          this.loadTokens();
        }
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
    this.tokenForm.reset({
      expireDate: '',
      price: '',
      challenge: '',
      quantity: 1,
      userPass: ''
    });
  }

  closeCreateModal() {
    this.showCreateModal.set(false);
    this.createdToken.set(null);
    this.tokenForm.reset();
  }

  createToken() {
    if (this.tokenForm.invalid) {
      return;
    }

    this.tokenLoading.set(true);
    const formValue = this.tokenForm.value;

    // Convert date to ISO string for backend
    const payload = {
      ...formValue,
      expireDate: new Date(formValue.expireDate).toISOString()
    };

    this.auth.createToken(payload).subscribe({
      next: (result) => {
        this.createdToken.set(result);
        this.tokenLoading.set(false);

        if (result.responseCode === 0) {
          this.loadTokens();
        }
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

  getCurrentDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  getActiveTokens() {
    const t = this.tokens();
    return Array.isArray(t) ? t.filter(t => t.status === 1) : [];
  }

  getRedeemedTokens() {
    const t = this.tokens();
    return Array.isArray(t) ? t.filter(t => t.status === 0) : [];
  }

  isExpired(token: any): boolean {
    if (!token.expireDate) return false;
    return new Date(token.expireDate) < new Date();
  }
}
