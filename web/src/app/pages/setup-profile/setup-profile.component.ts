import { Component, OnInit } from '@angular/core';
import { CommonModule, Location } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({
  // ... rest of imports
})
export class SetupProfileComponent implements OnInit {
  setupForm: FormGroup;
  errorMsg = '';
  isLoading = false;
  previewUrl: string | null = null;
  base64Image: string | null = null;

  constructor(
    private fb: FormBuilder,
    private auth: AuthService,
    private router: Router,
    private location: Location
  ) {
    this.setupForm = this.fb.group({
      companyName: ['', [Validators.required]],
      details: ['']
    });
  }

  ngOnInit() {
    const state = window.history.state;
    if (state && state['companyName']) {
      this.setupForm.patchValue({
        companyName: state['companyName']
      });
    }
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = () => {
        this.previewUrl = reader.result as string;
        this.base64Image = this.previewUrl;
      };
      reader.readAsDataURL(file);
    }
  }

  onSubmit() {
    this.isLoading = true;
    this.errorMsg = '';

    const payload = {
      companyName: this.setupForm.get('companyName')?.value,
      details: this.setupForm.get('details')?.value,
      picture: this.base64Image
    };

    this.auth.updateCompany(payload).subscribe({
      next: (res) => {
        this.isLoading = false;
        if (res.responseCode === 0) {
          this.location.back();
        } else {
          this.errorMsg = res.responseDesc || 'Update failed';
        }
      },
      error: (err) => {
        this.isLoading = false;
        this.errorMsg = 'Connection error';
        console.error(err);
      }
    });
  }

  skipSetup() {
    this.location.back();
  }
}
