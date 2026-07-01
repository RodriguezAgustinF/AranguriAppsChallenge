export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export type Database = {
  public: {
    Tables: {
      matches: {
        Row: {
          away_score: number | null;
          away_source_match_id: string | null;
          away_team_id: string | null;
          bracket_position: number;
          created_at: string;
          home_score: number | null;
          home_source_match_id: string | null;
          home_team_id: string | null;
          id: string;
          penalty_winner_team_id: string | null;
          result_published_at: string | null;
          stage_id: string;
          starts_at: string | null;
          tournament_id: string;
          updated_at: string;
        };
        Insert: {
          away_score?: number | null;
          away_source_match_id?: string | null;
          away_team_id?: string | null;
          bracket_position: number;
          created_at?: string;
          home_score?: number | null;
          home_source_match_id?: string | null;
          home_team_id?: string | null;
          id?: string;
          penalty_winner_team_id?: string | null;
          result_published_at?: string | null;
          stage_id: string;
          starts_at?: string | null;
          tournament_id: string;
          updated_at?: string;
        };
        Update: {
          away_score?: number | null;
          away_source_match_id?: string | null;
          away_team_id?: string | null;
          bracket_position?: number;
          created_at?: string;
          home_score?: number | null;
          home_source_match_id?: string | null;
          home_team_id?: string | null;
          id?: string;
          penalty_winner_team_id?: string | null;
          result_published_at?: string | null;
          stage_id?: string;
          starts_at?: string | null;
          tournament_id?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: "matches_away_source_match_id_fkey";
            columns: ["away_source_match_id"];
            isOneToOne: false;
            referencedRelation: "matches";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "matches_away_tournament_team_fkey";
            columns: ["tournament_id", "away_team_id"];
            isOneToOne: false;
            referencedRelation: "tournament_teams";
            referencedColumns: ["tournament_id", "team_id"];
          },
          {
            foreignKeyName: "matches_home_source_match_id_fkey";
            columns: ["home_source_match_id"];
            isOneToOne: false;
            referencedRelation: "matches";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "matches_home_tournament_team_fkey";
            columns: ["tournament_id", "home_team_id"];
            isOneToOne: false;
            referencedRelation: "tournament_teams";
            referencedColumns: ["tournament_id", "team_id"];
          },
          {
            foreignKeyName: "matches_penalty_winner_tournament_team_fkey";
            columns: ["tournament_id", "penalty_winner_team_id"];
            isOneToOne: false;
            referencedRelation: "tournament_teams";
            referencedColumns: ["tournament_id", "team_id"];
          },
          {
            foreignKeyName: "matches_stage_tournament_fkey";
            columns: ["stage_id", "tournament_id"];
            isOneToOne: false;
            referencedRelation: "stages";
            referencedColumns: ["id", "tournament_id"];
          },
          {
            foreignKeyName: "matches_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournament_overview";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "matches_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournaments";
            referencedColumns: ["id"];
          },
        ];
      };
      predictions: {
        Row: {
          away_score: number;
          created_at: string;
          home_score: number;
          id: string;
          match_id: string;
          penalty_winner_team_id: string | null;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          away_score: number;
          created_at?: string;
          home_score: number;
          id?: string;
          match_id: string;
          penalty_winner_team_id?: string | null;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          away_score?: number;
          created_at?: string;
          home_score?: number;
          id?: string;
          match_id?: string;
          penalty_winner_team_id?: string | null;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "predictions_match_id_fkey";
            columns: ["match_id"];
            isOneToOne: false;
            referencedRelation: "matches";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "predictions_penalty_winner_team_id_fkey";
            columns: ["penalty_winner_team_id"];
            isOneToOne: false;
            referencedRelation: "teams";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "predictions_user_id_fkey";
            columns: ["user_id"];
            isOneToOne: false;
            referencedRelation: "profiles";
            referencedColumns: ["id"];
          },
        ];
      };
      profiles: {
        Row: {
          created_at: string;
          id: string;
          name: string;
          role: Database["public"]["Enums"]["user_role"];
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          id: string;
          name: string;
          role?: Database["public"]["Enums"]["user_role"];
          updated_at?: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          name?: string;
          role?: Database["public"]["Enums"]["user_role"];
          updated_at?: string;
        };
        Relationships: [];
      };
      stages: {
        Row: {
          created_at: string;
          id: string;
          stage_order: number;
          tournament_id: string;
          type: Database["public"]["Enums"]["stage_type"];
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          stage_order: number;
          tournament_id: string;
          type: Database["public"]["Enums"]["stage_type"];
          updated_at?: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          stage_order?: number;
          tournament_id?: string;
          type?: Database["public"]["Enums"]["stage_type"];
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: "stages_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournament_overview";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "stages_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournaments";
            referencedColumns: ["id"];
          },
        ];
      };
      teams: {
        Row: {
          abbreviation: string;
          created_at: string;
          id: string;
          logo_path: string;
          name: string;
          updated_at: string;
        };
        Insert: {
          abbreviation: string;
          created_at?: string;
          id?: string;
          logo_path: string;
          name: string;
          updated_at?: string;
        };
        Update: {
          abbreviation?: string;
          created_at?: string;
          id?: string;
          logo_path?: string;
          name?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      tournament_scores: {
        Row: {
          created_at: string;
          id: string;
          points: number;
          tournament_id: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          points?: number;
          tournament_id: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          points?: number;
          tournament_id?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "tournament_scores_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournament_overview";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "tournament_scores_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournaments";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "tournament_scores_user_id_fkey";
            columns: ["user_id"];
            isOneToOne: false;
            referencedRelation: "profiles";
            referencedColumns: ["id"];
          },
        ];
      };
      tournament_teams: {
        Row: {
          created_at: string;
          draw_position: number | null;
          id: string;
          team_id: string;
          tournament_id: string;
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          draw_position?: number | null;
          id?: string;
          team_id: string;
          tournament_id: string;
          updated_at?: string;
        };
        Update: {
          created_at?: string;
          draw_position?: number | null;
          id?: string;
          team_id?: string;
          tournament_id?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: "tournament_teams_team_id_fkey";
            columns: ["team_id"];
            isOneToOne: false;
            referencedRelation: "teams";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "tournament_teams_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournament_overview";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "tournament_teams_tournament_id_fkey";
            columns: ["tournament_id"];
            isOneToOne: false;
            referencedRelation: "tournaments";
            referencedColumns: ["id"];
          },
        ];
      };
      tournaments: {
        Row: {
          bracket_generated_at: string | null;
          created_at: string;
          description: string | null;
          ends_at: string | null;
          id: string;
          name: string;
          starts_at: string;
          team_count: number;
          updated_at: string;
        };
        Insert: {
          bracket_generated_at?: string | null;
          created_at?: string;
          description?: string | null;
          ends_at?: string | null;
          id?: string;
          name: string;
          starts_at: string;
          team_count: number;
          updated_at?: string;
        };
        Update: {
          bracket_generated_at?: string | null;
          created_at?: string;
          description?: string | null;
          ends_at?: string | null;
          id?: string;
          name?: string;
          starts_at?: string;
          team_count?: number;
          updated_at?: string;
        };
        Relationships: [];
      };
    };
    Views: {
      tournament_overview: {
        Row: {
          bracket_generated_at: string | null;
          champion_team_id: string | null;
          created_at: string | null;
          description: string | null;
          ends_at: string | null;
          id: string | null;
          name: string | null;
          starts_at: string | null;
          status: string | null;
          team_count: number | null;
          updated_at: string | null;
        };
        Relationships: [];
      };
    };
    Functions: {
      generate_bracket: {
        Args: { target_tournament_id: string };
        Returns: undefined;
      };
      is_admin: { Args: never; Returns: boolean };
    };
    Enums: {
      stage_type: "ROUND_OF_32" | "ROUND_OF_16" | "QUARTER_FINAL" | "SEMI_FINAL" | "FINAL";
      user_role: "ADMIN" | "USER";
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">;

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R;
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R;
      }
      ? R
      : never
    : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    keyof DefaultSchema["Tables"] | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I;
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I;
      }
      ? I
      : never
    : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    keyof DefaultSchema["Tables"] | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U;
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U;
      }
      ? U
      : never
    : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    keyof DefaultSchema["Enums"] | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    keyof DefaultSchema["CompositeTypes"] | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never;

export const Constants = {
  public: {
    Enums: {
      stage_type: ["ROUND_OF_32", "ROUND_OF_16", "QUARTER_FINAL", "SEMI_FINAL", "FINAL"],
      user_role: ["ADMIN", "USER"],
    },
  },
} as const;
