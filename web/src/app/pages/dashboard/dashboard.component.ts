import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule, RouterModule],
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
  showSuggestions = false;
  createdToken = signal<any>(null);
  tokenLoading = signal(false);
  tokenForm: FormGroup;
  tokens = signal<any[]>([]);

  // Pagination
  PAGE_SIZE = 25;
  readonly PAGE_SIZE_OPTIONS = [10, 25, 50];
  activeTokenPage = 0;
  redeemedTokenPage = 0;

  setPageSize(size: number) {
    this.PAGE_SIZE = size;
    this.activeTokenPage = 0;
    this.redeemedTokenPage = 0;
  }

  constructor(private auth: AuthService, private router: Router, private fb: FormBuilder) {
    this.tokenForm = this.fb.group({
      expireDate: ['', Validators.required],
      price: ['', Validators.required],
      challenge: ['', Validators.required],
      quantity: [1, [Validators.required, Validators.min(1), Validators.max(100)]],
      requiredDistance: [null],
      requiredPace: [null, Validators.pattern(/^\d{1,2}:[0-5]\d$/)],
      userPass: ['', Validators.required]
    });
  }

  ngOnInit() {
    this.loadDashboardData();
  }

  navigateToSetup() {
    this.router.navigate(['/setup']);
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
        if (err.status === 403) {
          this.auth.logout(); // Use auth logout to clear state and redirect
        } else {
          this.error.set('Failed to load user data');
        }
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
    this.showSuggestions = false;
  }

  get filteredSuggestions() {
    const q = this.redeemCode.trim().toLowerCase();
    if (!q) return [];
    return this.getActiveTokens().filter(t =>
      t.tkn?.toLowerCase().includes(q) ||
      t.challenge?.toLowerCase().includes(q)
    ).slice(0, 8);
  }

  selectSuggestion(tkn: string) {
    this.redeemCode = tkn;
    this.showSuggestions = false;
  }

  copyToClipboard(text: string) {
    navigator.clipboard.writeText(text).then(() => {
      // Optional: Add a toast notification here later
      console.log('Token copied to clipboard');
    });
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
      requiredDistance: null,
      requiredPace: null,
      userPass: ''
    });
  }

  closeCreateModal() {
    this.showCreateModal.set(false);
    this.createdToken.set(null);
    this.tokenForm.reset();
  }

  /** Live input mask: formats raw digits into mm:ss as the user types */
  onPaceInput(event: Event) {
    const input = event.target as HTMLInputElement;
    // Keep only digits, cap at 4
    const digits = input.value.replace(/\D/g, '').slice(0, 4);
    let formatted = '';
    if (digits.length <= 2) {
      formatted = digits;
    } else {
      const mins = digits.slice(0, digits.length - 2);
      const secs = digits.slice(-2);
      formatted = `${mins}:${secs}`;
    }
    input.value = formatted;
    this.tokenForm.get('requiredPace')!.setValue(formatted, { emitEvent: false });
  }

  /** Convert "mm:ss" string to decimal min/km (e.g. "5:30" → 5.5) */
  private parsePace(pace: string | null): number | null {
    if (!pace) return null;
    const parts = pace.split(':');
    if (parts.length !== 2) return null;
    const mins = parseInt(parts[0], 10);
    const secs = parseInt(parts[1], 10);
    return mins + secs / 60;
  }

  createToken() {
    if (this.tokenForm.invalid) {
      return;
    }

    this.tokenLoading.set(true);
    const formValue = this.tokenForm.value;

    // Convert date (YYYY-MM-DD) to LocalDateTime-compatible string and pace from mm:ss to decimal
    const payload = {
      ...formValue,
      expireDate: formValue.expireDate + 'T00:00:00',
      requiredPace: this.parsePace(formValue.requiredPace)
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
    return Array.isArray(t) ? t.filter(t => t.status === 1 || t.status === 2) : [];
  }

  getPagedActiveTokens() {
    const start = this.activeTokenPage * this.PAGE_SIZE;
    return this.getActiveTokens().slice(start, start + this.PAGE_SIZE);
  }

  get activeTotalPages() {
    return Math.ceil(this.getActiveTokens().length / this.PAGE_SIZE);
  }

  getRedeemedTokens() {
    const t = this.tokens();
    return Array.isArray(t) ? t.filter(t => t.status === 0) : [];
  }

  getPagedRedeemedTokens() {
    const start = this.redeemedTokenPage * this.PAGE_SIZE;
    return this.getRedeemedTokens().slice(start, start + this.PAGE_SIZE);
  }

  get redeemedTotalPages() {
    return Math.ceil(this.getRedeemedTokens().length / this.PAGE_SIZE);
  }

  isExpired(token: any): boolean {
    if (!token.expireDate) return false;
    return new Date(token.expireDate) < new Date();
  }
}
