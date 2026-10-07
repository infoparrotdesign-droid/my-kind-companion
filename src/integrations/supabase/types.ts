export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.18"
  }
  public: {
    Tables: {
      brand_assets: {
        Row: {
          image_url: string | null
          type: string
          updated_at: string
        }
        Insert: {
          image_url?: string | null
          type: string
          updated_at?: string
        }
        Update: {
          image_url?: string | null
          type?: string
          updated_at?: string
        }
        Relationships: []
      }
      customer_interactions: {
        Row: {
          created_at: string
          customer_id: string
          happened_at: string
          id: string
          interaction_type: string
          note: string
        }
        Insert: {
          created_at?: string
          customer_id: string
          happened_at?: string
          id?: string
          interaction_type: string
          note: string
        }
        Update: {
          created_at?: string
          customer_id?: string
          happened_at?: string
          id?: string
          interaction_type?: string
          note?: string
        }
        Relationships: [
          {
            foreignKeyName: "customer_interactions_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
        ]
      }
      customers: {
        Row: {
          address: string
          created_at: string
          email: string | null
          id: string
          name: string
          phone: string
          reference: string | null
          updated_at: string
        }
        Insert: {
          address: string
          created_at?: string
          email?: string | null
          id?: string
          name: string
          phone: string
          reference?: string | null
          updated_at?: string
        }
        Update: {
          address?: string
          created_at?: string
          email?: string | null
          id?: string
          name?: string
          phone?: string
          reference?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      order_items: {
        Row: {
          created_at: string
          id: string
          order_id: string
          product_code: string | null
          product_id: string | null
          product_name: string
          quantity: number
          subtotal: number
          unit_price: number
        }
        Insert: {
          created_at?: string
          id?: string
          order_id: string
          product_code?: string | null
          product_id?: string | null
          product_name: string
          quantity: number
          subtotal: number
          unit_price: number
        }
        Update: {
          created_at?: string
          id?: string
          order_id?: string
          product_code?: string | null
          product_id?: string | null
          product_name?: string
          quantity?: number
          subtotal?: number
          unit_price?: number
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      order_status_history: {
        Row: {
          changed_at: string
          changed_by: string | null
          from_status: string | null
          id: string
          order_id: string
          to_status: string
        }
        Insert: {
          changed_at?: string
          changed_by?: string | null
          from_status?: string | null
          id?: string
          order_id: string
          to_status: string
        }
        Update: {
          changed_at?: string
          changed_by?: string | null
          from_status?: string | null
          id?: string
          order_id?: string
          to_status?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_status_history_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          amount_paid: number
          created_at: string
          customer_email: string | null
          customer_id: string | null
          customer_name: string | null
          customer_phone: string | null
          delivery_address: string | null
          delivery_reference: string | null
          financial_updated_at: string
          id: string
          notes: string | null
          order_code: string
          order_type: string
          payment_method: string | null
          payment_notes: string | null
          payment_status: string
          quoted_total: number | null
          service_description: string | null
          service_title: string | null
          service_type: string | null
          source: string
          status: string
          total: number
          updated_at: string
          whatsapp_sent_at: string | null
        }
        Insert: {
          amount_paid?: number
          created_at?: string
          customer_email?: string | null
          customer_id?: string | null
          customer_name?: string | null
          customer_phone?: string | null
          delivery_address?: string | null
          delivery_reference?: string | null
          financial_updated_at?: string
          id?: string
          notes?: string | null
          order_code: string
          order_type: string
          payment_method?: string | null
          payment_notes?: string | null
          payment_status?: string
          quoted_total?: number | null
          service_description?: string | null
          service_title?: string | null
          service_type?: string | null
          source?: string
          status?: string
          total?: number
          updated_at?: string
          whatsapp_sent_at?: string | null
        }
        Update: {
          amount_paid?: number
          created_at?: string
          customer_email?: string | null
          customer_id?: string | null
          customer_name?: string | null
          customer_phone?: string | null
          delivery_address?: string | null
          delivery_reference?: string | null
          financial_updated_at?: string
          id?: string
          notes?: string | null
          order_code?: string
          order_type?: string
          payment_method?: string | null
          payment_notes?: string | null
          payment_status?: string
          quoted_total?: number | null
          service_description?: string | null
          service_title?: string | null
          service_type?: string | null
          source?: string
          status?: string
          total?: number
          updated_at?: string
          whatsapp_sent_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "orders_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "customers"
            referencedColumns: ["id"]
          },
        ]
      }
      portfolio_projects: {
        Row: {
          category: string
          client: string | null
          created_at: string
          description: string
          featured: boolean
          id: string
          image: string | null
          project_year: number | null
          sort_order: number
          title: string
          updated_at: string
        }
        Insert: {
          category?: string
          client?: string | null
          created_at?: string
          description?: string
          featured?: boolean
          id?: string
          image?: string | null
          project_year?: number | null
          sort_order?: number
          title: string
          updated_at?: string
        }
        Update: {
          category?: string
          client?: string | null
          created_at?: string
          description?: string
          featured?: boolean
          id?: string
          image?: string | null
          project_year?: number | null
          sort_order?: number
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      products: {
        Row: {
          available: boolean
          category: string
          code: string
          created_at: string
          description: string
          id: string
          image: string | null
          name: string
          price: number
          stock: number
          updated_at: string
        }
        Insert: {
          available?: boolean
          category: string
          code?: string
          created_at?: string
          description?: string
          id: string
          image?: string | null
          name: string
          price?: number
          stock?: number
          updated_at?: string
        }
        Update: {
          available?: boolean
          category?: string
          code?: string
          created_at?: string
          description?: string
          id?: string
          image?: string | null
          name?: string
          price?: number
          stock?: number
          updated_at?: string
        }
        Relationships: []
      }
      service_requests: {
        Row: {
          created_at: string
          id: string
          order_id: string
          requested_details: Json
          service_description: string | null
          service_title: string
          service_type: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          order_id: string
          requested_details?: Json
          service_description?: string | null
          service_title: string
          service_type?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          order_id?: string
          requested_details?: Json
          service_description?: string | null
          service_title?: string
          service_type?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "service_requests_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_requests_service_type_fkey"
            columns: ["service_type"]
            isOneToOne: false
            referencedRelation: "services"
            referencedColumns: ["type"]
          },
        ]
      }
      services: {
        Row: {
          created_at: string
          description: string
          image: string | null
          title: string
          type: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string
          image?: string | null
          title: string
          type: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string
          image?: string | null
          title?: string
          type?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      create_public_order: {
        Args: { p_items?: Json; p_order: Json; p_service?: Json }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
